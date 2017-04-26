# Arrays that hold grades and corresponding point values
grades = ["A+", "A", "A-", "B+", "B", "B-", "C+", "C", "C-", "D+", "D", "D-", "F"]
gradepoints = [4.33, 4.0, 3.67, 3.33, 3.0, 2.67, 2.33, 2.0, 1.67, 1.33, 1.0, 0.67, 0.0]
simplegrades = ["A", "B", "C", "D", "E", "F"]
simplegradepoints = [4.0, 3.0, 2.0, 1.0, 0.0]

# Converts a grade to a numerical value
function gradeconvert(grade; expanded=true)
    # The expanded variable determines wheter pluses and minuses
    # are accounted for, or discounted.

    # Stores a translation dictionary
    translation = nothing

    if expanded
        # Expanded Translation
        translation = Dict(
            "A+"    => 4.33,
            "A"     => 4.0,
            "A-"    => 3.67,
            "B+"    => 3.33,
            "B"     => 3.0,
            "B-"    => 2.67,
            "C+"    => 2.33,
            "C"     => 2.0,
            "C-"    => 1.67,
            "D+"    => 1.33,
            "D"     => 1.0,
            "D-"    => 0.67,
            "F"     => 0.0
        )
    else
        # Truncated Translation
        translation = Dict(
            "A+"    => 4.0,
            "A"     => 4.0,
            "A-"    => 3.0,
            "B+"    => 3.0,
            "B"     => 3.0,
            "B-"    => 2.0,
            "C+"    => 2.0,
            "C"     => 2.0,
            "C-"    => 1.0,
            "D+"    => 1.0,
            "D"     => 1.0,
            "D-"    => 0.0,
            "F"     => 0.0
        )
    end

    if in(grade, grades)
        # Checks for a standard grade and tralsate. 
        return translation[grade]
    else
        # Otherwise, return 0.0
        return 0.0
    end
end


# Converts a numerical value to a grade
function valueconvert(value; expanded=true)
    # The expanded variable determines wheter pluses and minuses
    # are accounted for, or discounted.

    # Variables to hold grade and point arrays depending on the
    # expanded variable
    g = nothing; p = nothing

    if expanded
        g = grades
        p = gradepoints
    else
        g = simplegrades
        p = simplegradepoints
    end

    # Find point value closests to passed in value
    diffs = abs(p .- value)
    ind = indmin(diffs)

    # Return corresponding grade
    return g[ind]
end


# Converts a numerical value to a grade
function nearestvalue(value; expanded=true)
    # The expanded variable determines wheter pluses and minuses
    # are accounted for, or discounted.

    # Variables to hold grade and point arrays depending on the
    # expanded variable
    g = nothing; p = nothing

    if expanded
        g = grades
        p = gradepoints
    else
        g = simplegrades
        p = simplegradepoints
    end

    # Find point value closests to passed in value
    diffs = abs(p .- value)
    ind = indmin(diffs)

    # Return corresponding grade
    return p[ind]
end