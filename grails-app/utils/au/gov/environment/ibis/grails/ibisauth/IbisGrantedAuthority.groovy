package au.gov.environment.ibis.grails.ibisauth

import org.springframework.security.core.*

class IbisGrantedAuthority implements GrantedAuthority {
    public static final IbisGrantedAuthority NO_ROLES = new IbisGrantedAuthority('NO_ROLES');
    public static final Collection<GrantedAuthority> NO_ROLES_V = Collections.unmodifiableCollection(new ArrayList<GrantedAuthority>([NO_ROLES]));

    private final String auth;

    IbisGrantedAuthority(String auth) {
        this.auth = auth;
    }

    @Override
    String getAuthority() {
        auth;
    }

    String toString() {
        auth;
    }
}
