package au.gov.environment.ibis.grails.ibisauth

import org.apache.commons.logging.LogFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.security.authentication.*
import org.springframework.security.core.*
import org.springframework.security.core.userdetails.UsernameNotFoundException

/**
 * Created with IntelliJ IDEA.
 * User: ibis
 * Date: 29/05/13
 * Time: 4:59 PM
 * To change this template use File | Settings | File Templates.
 */

class IbisAuthenticationService implements AuthenticationProvider {
    private static final log = LogFactory.getLog(this)

    // injected user details service
    @Autowired
    IbisUserDetailsService ibisUserDetailsService;

    static {
        log.info 'IbisAuthenticationService class loaded'
    }

    {
        log.info 'IbisAuthenticationService instance loaded'
    }


    @Override
    Authentication authenticate(Authentication authentication) throws AuthenticationException {
        if(authentication instanceof UsernamePasswordAuthenticationToken) {
            return authenticate((UsernamePasswordAuthenticationToken) authentication);
        }

        // this should never happen
        throw new AuthenticationFailed("Unrecognised authentication type");
    }

    Authentication authenticate(UsernamePasswordAuthenticationToken authentication) throws AuthenticationException {
        String userName = (String) authentication.principal;
        String password = (String) authentication.credentials;

        // this code completely ignores password
        try {
            IbisUserDetails d = ibisUserDetailsService.loadUserByUsername(userName);
            return new IbisAuthentication(authentication, d);
        }
        catch(UsernameNotFoundException ex) {
            throw new BadCredentialsException(userName, ex);
        }
    }

    @Override
    boolean supports(Class<? extends Object> aClass) {
        if(UsernamePasswordAuthenticationToken.class.isAssignableFrom(aClass)) {
            return true;
        }

        return false;
    }

    public static class AuthenticationFailed extends AuthenticationException {
        public AuthenticationFailed(String msg, Throwable t) { super(msg, t); }

        public AuthenticationFailed(String msg) { super(msg); }

    }
}
