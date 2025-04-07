import FaceLiveness
import CafFaceAuth

extension FaceAuthPlugin {
    
    struct Constants {
        static let start = "start"
        static let methodChannelName = "face_authenticator"
        static let eventChannelName = "face_auth_listener"
        static let viewControllerErrorMessage = "Error getting curren key window view controller"
        static let argumentsErrorMessage = "Critical error: unable to get argument mapping"
        static let mobileTokenErrorMessage = "Critical error: unable to get mobileToken"
        static let personIdErrorMessage = "Critical error: unable to get personID"
        static let eventCanceled = "canceled"
        static let eventConnected = "connected"
        static let eventConnecting = "connecting"
        static let eventError = "failure"
        static let eventSuccess = "success"
        static let eventValidated = "validated"
        static let eventValidating = "validating"
    }
    
    func getCafStage(stage: String) -> CafFaceAuth.CafEnvironment {
        switch stage {
        case "PROD":
            return CafEnvironment.prod
        case "BETA":
            return CafEnvironment.beta
        default:
            return CafEnvironment.prod
        }
    }
    
    func getExpirationTime(time: String) -> Time {
        switch time {
        case "THIRTY_DAYS":
            return Time.thirtyDays
        case "THREE_HOURS":
            return Time.threeHours
        default:
            return Time.thirtyMin
        }
    }
    
    func getFilter(filter: String) -> Filter {
        if (filter == "NATURAL") {
            return Filter.natural
        } else {
            return Filter.lineDrawing
        }
    }
}
