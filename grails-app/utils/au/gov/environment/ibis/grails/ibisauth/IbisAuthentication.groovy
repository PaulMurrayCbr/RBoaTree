package au.gov.environment.ibis.grails.ibisauth

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.Authentication

/**
 * Created with IntelliJ IDEA.
 * User: ibis
 * Date: 29/05/13
 * Time: 6:11 PM
 * To change this template use File | Settings | File Templates.
 */
class IbisAuthentication implements Authentication {
    UsernamePasswordAuthenticationToken c;
    final IbisUserDetails d;

    IbisAuthentication(UsernamePasswordAuthenticationToken c, IbisUserDetails d) {
        this.c = c;
        this.d = d;
    }

    String getName() { return d.username; }

    Collection<IbisGrantedAuthority> getAuthorities() {return d.authorities;}

    Object getCredentials() { return c;}

    Object getDetails() { return d;}

    Object getPrincipal() { return this;}

    boolean isAuthenticated() { return true; }

    void setAuthenticated(boolean b) {
        throw new UnsupportedOperationException();
    }
}
