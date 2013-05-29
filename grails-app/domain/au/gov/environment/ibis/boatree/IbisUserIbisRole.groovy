package au.gov.environment.ibis.boatree

import org.apache.commons.lang.builder.HashCodeBuilder

class IbisUserIbisRole implements Serializable {

	IbisUser ibisUser
	IbisRole ibisRole

	boolean equals(other) {
		if (!(other instanceof IbisUserIbisRole)) {
			return false
		}

		other.ibisUser?.id == ibisUser?.id &&
			other.ibisRole?.id == ibisRole?.id
	}

	int hashCode() {
		def builder = new HashCodeBuilder()
		if (ibisUser) builder.append(ibisUser.id)
		if (ibisRole) builder.append(ibisRole.id)
		builder.toHashCode()
	}

	static IbisUserIbisRole get(long ibisUserId, long ibisRoleId) {
		find 'from IbisUserIbisRole where ibisUser.id=:ibisUserId and ibisRole.id=:ibisRoleId',
			[ibisUserId: ibisUserId, ibisRoleId: ibisRoleId]
	}

	static IbisUserIbisRole create(IbisUser ibisUser, IbisRole ibisRole, boolean flush = false) {
		new IbisUserIbisRole(ibisUser: ibisUser, ibisRole: ibisRole).save(flush: flush, insert: true)
	}

	static boolean remove(IbisUser ibisUser, IbisRole ibisRole, boolean flush = false) {
		IbisUserIbisRole instance = IbisUserIbisRole.findByIbisUserAndIbisRole(ibisUser, ibisRole)
		if (!instance) {
			return false
		}

		instance.delete(flush: flush)
		true
	}

	static void removeAll(IbisUser ibisUser) {
		executeUpdate 'DELETE FROM IbisUserIbisRole WHERE ibisUser=:ibisUser', [ibisUser: ibisUser]
	}

	static void removeAll(IbisRole ibisRole) {
		executeUpdate 'DELETE FROM IbisUserIbisRole WHERE ibisRole=:ibisRole', [ibisRole: ibisRole]
	}

	static mapping = {
		id composite: ['ibisRole', 'ibisUser']
		version false
	}
}
