# include("../src/CurricularAnalyticsSimulationLibrary.jl")
using CurricularAnalyticsSimulationLibrary
using Test

# Testing Students
student = Student(1, Dict())
@test student.id == 1
@test student.gpa == 0.0
@test student.total_credits == 0
@test student.total_points == 0
@test student.termcredits == 0
@test_throws MethodError Student()
@test_throws MethodError Student(1.4, Dict())
@test_throws MethodError Student(1, 8)

# Testing Course
c1 = Course("Course One", 3, Course[], Course[])
c2 = Course("Course Two", 3, Course[], Course[])
c3 = Course("Course Three", 3, [c1], Course[])
c4 = Course("Course Four", 3, [c1], Course[])
@test length(c1.postreqs) == 2
@test length(c3.prereqs) == 1
cruciality(c1)
cruciality(c2)
cruciality(c3)
cruciality(c4)
@test c1.delay == 2
@test c1.blocking == 2
@test c1.cruciality == 4
@test c2.cruciality == 1
@test c3.cruciality == 2
@test c4.cruciality == 2

# Testing Curriculum
curriculum = Curriculum("Test Curriculum", "./test_curriculum.json")
@test curriculum.numCourses == 4
@test curriculum.courses[1].cruciality == 4
@test curriculum.complexity == 9
@test curriculum.delay == 7
@test curriculum.blocking == 2

# Test Simulation with Passrate Model
# sim = Simulation(curriculum)
students = simpleStudents(10)
sim = simulate(curriculum, students, max_credits = 9, duration = 1)
@test sim.gradRate == 0.0
@test c3.enrolled == 0
@test c4.enrolled == 0