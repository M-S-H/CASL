function passTable(simulation, semesters=-1)
    frame = DataFrame()

    # Make Keys
    frame[:COUSE] = []
    terms = simulation.duration

    if semesters > -1
        terms = semesters
    end

    for i=1:terms
        frame[Symbol("TERM$(i)")] = []
    end

    # Populate data
    for course in simulation.curriculum.courses
        row = [course.name]
        prev = 0
        for i=1:terms
            prev += course.termpassed[i]
            row = [row round((prev/simulation.numStudents)*100, 3)]
        end
        push!(frame, row)
    end

    rates = ["GRAD RATE"]
    for i=1:terms
        rates = [rates round(simulation.termGradRates[i]*100, 3)]
    end
    push!(frame, rates)

    frame
end