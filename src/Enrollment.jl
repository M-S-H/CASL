module LinearEnrollment
    using CASL: Student

    function enroll!(currentTerm, simulation, max_credits)
        studentProgress = simulation.studentProgress
        terms = simulation.curriculum.terms
        
        for (termnum, term) in enumerate(terms)
            # Itterate through courses
            for course in term.courses
                # Clear the array of enrolled students for the course
                course.students = Student[]

                for student in simulation.enrolledStudents
                    # Enroll in coreqs first
                    for coreq in course.coreqs
                        if canEnroll(student, coreq, studentProgress, max_credits, currentTerm)
                            # Enroll the student in the course
                            push!(course.students, student)

                            # Increment the course's enrollment counters
                            course.enrolled += 1
                            course.termenrollment[currentTerm] += 1

                            # Increse the student's term credits
                            student.termcredits += course.credits
                        end
                    end

                    # Determine wheter the student can be enrolled in the current course.
                    if canEnroll(student, course, studentProgress, max_credits, currentTerm)

                        # Enroll the student in the course
                        push!(course.students, student)

                        # Increment the course's enrollment counters
                        course.enrolled += 1
                        course.termenrollment[currentTerm] += 1

                        # Increse the student's term credits
                        student.termcredits += course.credits
                    end
                end
            end 
        end
    end

    # Function that determines wheter a student can enroll in a course
    function canEnroll(student, course, studentProgress, max_credits, term)
        # Find the prereq ids of the current course
        prereqIds = map(x -> x.id, course.prereqs)

        !in(student, course.students) &&
        (length(course.prereqs) == 0 || sum(studentProgress[student.id, prereqIds]) == length(course.prereqs)) &&       # No Prereqs or the student has completed them
        studentProgress[student.id, course.id] == 0.0 &&                                                                # The student has not already completed the course
        student.termcredits + course.credits <= max_credits &&                                                          # The student will not exceed the maximum number of credit hours
        course.termReq <= term &&                                                                                       # The student must wait until the term req has been met
        enrolledInCoreqs(student, course, studentProgress)                                                              # The student is enrolled in or has completed coreqs
    end

    # Determines whether a student is enrolled in or has completed coreqs for a given course
    function enrolledInCoreqs(student, course, studentProgress)
        enrolled = true

        for coreq in course.coreqs
            enrolled =  enrolled && (in(student, coreq.students) || studentProgress[student.id, coreq.id] == 1.0)
        end

        return enrolled
    end
end