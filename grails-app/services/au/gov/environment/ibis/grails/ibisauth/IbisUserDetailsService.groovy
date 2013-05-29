package au.gov.environment.ibis.grails.ibisauth

import org.apache.commons.logging.LogFactory
import org.codehaus.groovy.grails.plugins.springsecurity.GrailsUserDetailsService
import org.springframework.dao.DataAccessException
import org.springframework.security.core.userdetails.*


class IbisUserDetailsService implements UserDetailsService {
    private static final log = LogFactory.getLog(this)

    static Collection<String> users = ['guest', 'a'];

    static {
        log.info 'IbisUserDetailsService class loaded'
    }

    {
        log.info 'IbisUserDetailsService instance loaded'
    }

    @Override
    IbisUserDetails loadUserByUsername(String username) throws UsernameNotFoundException, DataAccessException {
        if(users.contains(username)) {
            IbisUserDetails u = IbisUserDetails.buildSimpleUser(username);
            return u;
        }

        throw new UsernameNotFoundException(username);
    }
}
