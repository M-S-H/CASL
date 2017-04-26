type Course
    name::AbstractString            # Name of the course
    id::Int                         # Unique id for course
    term::Int                       # The term the course belongs to

    credits::Int                    # Course credit hours
    delay::Int                      # The course's delay factor - the value of the longest path the course is on
    blocking::Int                   # The course's blocking factor - the number of courses blocked by this course
    cruciality::Int                 # The sum of the delay and blocking factor
    centrality::Int                 # Course centrality
    reachability::Int               # Course reachability

    prereqs::Array{Course}          # Array of courses that are a prerequisite to this course
    coreqs::Array{Course}           # Array of courses that must be taken in the same term or before
    postreqs::Array{Course}         # Array of courses that has this course as a prerequisite
    termReq::Int                    # Number of terms that must be completed before enrolling

    students::Array{Student}        # Array of students enrolled in this course in a given term

    model::Dict                     # Dictionary to hold information for grade predictions
    passrate::Float64               # Percentage of students that pass the course
    failures::Int                   # Total number of students who do not pass the course
    grades::Array{Float64}          # Array of all grades made in the course
    enrolled::Int                   # Total number of students that are enrolled in the course
    termenrollment::Array{Int}      # An array of enrollment by term
    termpassed::Array{Int}          # An array of the number of students who pass each term

    # Minimum Information Required
    function Course(name::AbstractString, credits::Number, prereqs::Array{Course}, coreqs::Array{Course})
        this = new()

        this.name = name
        this.credits = credits
        this.prereqs = prereqs
        this.postreqs = Course[]
        this.coreqs = Course[]
        this.termReq = 0

        # Assign current course as postreq for prereqs
        for c in this.prereqs
            push!(c.postreqs, this)
        end

        this.passrate = 0
        this.failures = 0
        this.enrolled = 0
        this.grades = Float64[]
        this.students = Student[]

        return this
    end

    # With Passrate
    function Course(name::AbstractString, credits::Number, passrate::Number, prereqs::Array{Course}, coreqs::Array{Course})
        this = Course(name, credits, prereqs, coreqs)
        this.passrate = passrate
        return this
    end

    # With termReq
    function Course(name::AbstractString, credits::Number, prereqs::Array{Course}, coreqs::Array{Course}, termReq::Number)
        this = Course(name, credits, prereqs, coreqs)
        this.termReq = termReq
        return this
    end

    # With termReq and Passrate
    function Course(name::AbstractString, credits::Number, termReq::Number, passrate::Number, prereqs::Array{Course}, coreqs::Array{Course})
        this = Course(name, credits, prereqs, coreqs)
        this.termReq = termReq
        this.passrate = passrate
        return this
    end
end


# Helper Functions

# Compute the cruciality, delay, and blocking factor of a course
function cruciality(course::Course)
    b = blocking(course)
    d = delay(course)

    course.blocking = b
    course.delay = d
    course.cruciality = d + b
end

# Compute the blocking factor of a course
function blocking(course, b=-1, courses=[])
    for c in course.postreqs
        b += blocking(c, 0, courses)
    end

    if !in(course.name, courses)
        b += 1
        push!(courses, course.name)
    end

    return b
end

# Compute the delay factor of a course
function delay(course)
    # Traverse forward from course
    f = []
    forward(course, f)

    # Traverse backwards from course
    b = []
    backward(course, b)

    return maximum(f) + maximum(b) + 1
end

# Determines all path length (l) from course and stores them in path
function forward(course, paths, l=0)
    # Keep traversing forward
    for c in course.postreqs
        forward(c, paths, l+1)
    end

    # If no postreqs, record path length
    if length(course.postreqs) == 0
        push!(paths, l)
    end
end

# Determines all path length (l) behind course and stores them in path
function backward(course, paths, l=0)
    # Keep traversing backward
    for c in [course.prereqs; course.coreqs]
        backward(c, paths, l+1)
    end

    # If no prereqs, record path length
    if length(course.prereqs) == 0
        push!(paths, l)
    end
end

