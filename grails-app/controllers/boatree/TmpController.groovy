package boatree

class TmpController {

    /**
     * Dependency injection for the authenticationTrustResolver.
     */
    def authenticationTrustResolver

    /**
     * Dependency injection for the springSecurityService.
     */
    def springSecurityService


    def index() {
        [msg: 'This is a message', sec: springSecurityService]

    }
}
