import Foundation

protocol PersonRepository {
    /// Cache-first read. Does not trigger network.
    func getPeople() async -> Result<[Person], Error>

    /// Always hits network, updates local cache, returns fresh data.
    func refreshPeople() async -> Result<[Person], Error>

    func getPersonById(_ id: Int) async -> Result<Person, Error>
    func refreshPerson(id: Int) async -> Result<Person, Error>

    func deleteItem(id: Int) async -> Result<Void, Error>
}
