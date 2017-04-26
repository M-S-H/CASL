type Term
    courses::Array{Course}      # Array of courses for the term
    totalEnrolled::Int          # Total number of students enrolled
    failures::Int               # Number of failures within the term

    function Term(courses::Array{Course})
        this = new()

        this.courses = courses
        this.totalEnrolled = 0
        this.failures = 0

        return this
    end
end