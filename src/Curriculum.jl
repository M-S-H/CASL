mutable struct Curriculum
    name::AbstractString        # Name of the curriculum (can be used as an identifier)
    terms::Array{Term}          # Array of terms in order
    courses::Array{Course}      # Array of courses in the curriculum
    numCourses::Int             # Number of courses in curriculum
    creditHours::Int            # Number of credit hours
    
    complexity::Int             # Sum of all course crucialities
    delay::Int                  # Sum of course delay factors
    blocking::Int               # Sum of course blocking factors
    centrality::Int             # Total Centrality
    reachability::Int           # Total Reachability
    
    passrate::Float64           # Average passrate of courses
    stopoutModel::Dict          # Dictionary that stores the the model for predicint stopouts
    
    graph::Any                  # LightGraph representation

    function Curriculum(curriculumName::AbstractString, terms::Array{Term})
        this = new()

        this.name = curriculumName
        this.terms = terms
        this.courses = Course[]

        for (i, term) in enumerate(terms)
            for course in term.courses
                # Add courses to array
                push!(this.courses, course)

                # Add postreq links
                for prereq in course.prereqs
                    push!(prereq.postreqs, course)
                end

                # Add co reqs
                for coreq in course.coreqs
                    push!(coreq.postreqs, course)
                end

                # Mark term the course belongs to
                course.term = i
            end
        end

        for (id, course) in enumerate(this.courses)
            # Compute complexity
            course.id = id
            cruciality(course)
        end

        # Create graph
        this.graph = curriculumGraph(this)

        # Compute centrality
        this.centrality = curriculumCentrality!(this)

        # Compute reachability
        this.reachability = curriculumReachability!(this)

        this.complexity = sum(map(x->x.cruciality, this.courses))
        this.delay = sum(map(x->x.delay, this.courses))
        this.blocking = sum(map(x->x.blocking, this.courses))
        this.numCourses = length(this.courses)
        this.passrate = sum(map(x->x.passrate, this.courses)) / this.numCourses
        this.stopoutModel = Dict()

        this.creditHours = sum(map(x->x.credits, this.courses))

        return this
    end


    function Curriculum(curriculumName::AbstractString, data::Dict)
        # Sort courses by term
        sort!(data["courses"], by = x -> x["term"])

        # Get number of terms
        terms = data["terms"]

        # Array of course arrays, one for each term
        courses = Array{Array{Course}}(terms)
        for i=1:terms
            courses[i] = Course[]
        end

        allCourses = Course[]

        # Create all course objects
        for course in data["courses"]
            name = course["name"]
            credits = course["credits"]
            passrate = course["passrate"]
            haskey(data, "termReq") ? termReq = data["termReq"] : termReq = 0

            c = Course(name, credits, termReq, passrate, Course[], Course[])
            push!(courses[course["term"]], c)
            push!(allCourses, c)
        end

        # Assign pre and coreqs
        for (i, course) in enumerate(data["courses"])
            c = allCourses[i]

            # Prereqs
            prereqs = Course[]
            for prereq in course["prerequisites"]
                ind = findfirst(x -> x.name == prereq, allCourses)
                if ind != 0
                    push!(prereqs, allCourses[ind])
                end
            end

            # Coreqs
            coreqs = Course[]
            for coreq in course["corequisites"]
                ind = findfirst(x -> x.name == coreq, allCourses)
                if ind != 0
                    push!(coreqs, allCourses[ind])
                end
            end

            c.prereqs = prereqs
            c.coreqs = coreqs
        end

        terms = Term[]
        for courseArray in courses
            push!(terms, Term(courseArray))
        end

        this = Curriculum(curriculumName, terms)
        return this
    end


    function Curriculum(curriculumName::AbstractString, path::AbstractString)
        f = open(path)
        data = JSON.parse(read(f))
        close(f)

        this = Curriculum(curriculumName, data)
        return this
    end
end


function curriculumGraph(curriculum)
    numCourses = length(curriculum.courses)

    graph = DiGraph(numCourses)

    for course in curriculum.courses
        for prereq in course.prereqs
            add_edge!(graph, prereq.id, course.id)
        end
    end

    return graph
end


function curriculumCentrality!(curriculum)
    measures = zeros(length(curriculum.courses))

    adj = adjacency_matrix(curriculum.graph)

    for i=1:length(curriculum.courses)
        for j=1:length(curriculum.courses)
            paths = path_enumeration(i, j, adj)
            all_nodes = []
            for p in paths
                all_nodes = vcat(all_nodes, p.path)
            end

            for v in unique(all_nodes)
                measures[v] += 1
            end
        end
    end

    for (i, measure) in enumerate(measures)
        curriculum.courses[i].centrality = measure
    end

    return sum(measures)
end

function curriculumReachability!(curriculum)
    newC = deepcopy(curriculum)

    for course in newC.courses
        course.prereqs = Course[]
        course.postreqs = Course[]
    end

    for (ci, course) in enumerate(curriculum.courses)
        for prereq in course.prereqs
            push!(newC.courses[ci].postreqs, newC.courses[prereq.id])
        end
    end

    for (i, course) in enumerate(newC.courses)
        cruciality(course)
        curriculum.courses[i].reachability = course.blocking
    end

    return sum(map(x->x.blocking, newC.courses))
end