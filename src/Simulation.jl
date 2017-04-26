type Simulation
    curriculum::Curriculum                  # The curriculum that is simulated
    duration::Int                           # The number of terms the simulation runs for

    predictionModel::Module                 # Module that implements the model for predicting student's performance in courses

    numStudents::Int                        # The number of students in the simulation
    enrolledStudents::Array{Student}        # Array of students that are enrolled
    graduatedStudents::Array{Student}       # Array of students that have graduated
    stopoutStudents::Array{Student}         # Array of students who stopped out

    studentProgress::Array{Int}             # Indicates wheter students have passed each course

    gradRate::Float64                       # Graduation rate at the end of the simulation
    termGradRates::Array{Float64}           # Array of graduation rates at the end of the simulation
    timeToDegree::Float64                   # Average number of semesters it takes to graduate students
    stopoutRate::Float64                    # Stopout rate at the end of the simulation
    termStopoutRates::Array{Float64}        # Array of stopout rates for each term

    function Simulation(curriculum)
        this = new()

        this.curriculum = curriculum

        this.enrolledStudents = Student[]
        this.graduatedStudents = Student[]
        this.stopoutStudents = Student[]

        # Set up courses
        for (id, course) in enumerate(curriculum.courses)
            course.id = id
        end

        return this
    end
end