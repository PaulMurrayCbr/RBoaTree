package au.gov.environment.ibis.grails.ibisauth

import org.apache.commons.logging.LogFactory
import org.codehaus.groovy.grails.plugins.springsecurity.GrailsUser
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.userdetails.User;

class IbisUserDetails extends User {
    private static final log = LogFactory.getLog(this)

    public static IbisUserDetails buildSimpleUser(String username) {
        log.debug 'new user ' + username;
        IbisUserDetails u = new IbisUserDetails(username, 'password', true, true, true, true, IbisGrantedAuthority.NO_ROLES_V);
        log.debug 'created ' + u;
        return u;
    }

    public IbisUserDetails(String username,
                           String password,
                           boolean enabled,
                           boolean accountNonExpired,
                           boolean credentialsNonExpired,
                           boolean accountNonLocked,
                           Collection<GrantedAuthority> authorities) {
        super(username, password, enabled, accountNonExpired, credentialsNonExpired, accountNonLocked, authorities);
    }

    public String toString() {
        String s =  "username:" + username + ", password:" + password + ", enabled:" + enabled + //
                    ", accountNonExpired:" + accountNonExpired +
                    ", credentialsNonExpired:" + credentialsNonExpired +
                    ", accountNonLocked:" + accountNonLocked +
                    ", authorities:" + authorities;

        return s;
    }

    public void eraseCredentials () {
        log.warn('ERASING CREDENTIALS!');
        log.warn('BEFORE: ' + this);
        //super.eraseCredentials();
        log.warn('AFTER: ' + this);
    }
}
