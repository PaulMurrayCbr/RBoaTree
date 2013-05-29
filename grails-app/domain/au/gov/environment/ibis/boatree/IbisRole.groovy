package au.gov.environment.ibis.boatree

class IbisRole {

	String authority

	static mapping = {
		cache true
	}

	static constraints = {
		authority blank: false, unique: true
	}
}
