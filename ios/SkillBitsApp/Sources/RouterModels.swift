import Foundation
import SkillBitsCore

enum TabItem: Hashable {
    case home
    case courses
    case myStudy
    case progress
    case profile
}

struct CourseNavContext: Hashable {
    let course: Course
}
