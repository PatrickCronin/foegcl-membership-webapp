# Schema Design Notes

## Design Considerations

### Donations

* Donations are recorded against affililiations; not against individuals.

### Affiliations

* Affiliations may have a membership type assigned, making that particular affiliation also a membership. Memberships have a minimum donation sum requirement and a maximum person requirement, which is enforced by triggers.

### People

* All people sharing an affiliation of the current year should have the same physical and mailing addresses, both of which can be empty. This requirement cannot be enforced for historical years as we only store "current" addresses for people.

## Trigger Design

Triggers are used to support the following business rules that are not naturally supported by the schema design.

### Donations

* UPDATE Triggers
    * Updates that move a donation to another affiliation are blocked. (If needed, users can delete and create.) (Done)
    * Updates that disqualify a membership's donation sum requirement are blocked. (Done)
* DELETE Triggers
    * Deletes that disqualify a membership's donation sum requirement are blocked. (Done)

### Affiliations
* INSERT Triggers
    * Inserts including a NOT NULL membership_type will be blocked.
* UPDATE Triggers
    * Updates changing the affiliation's membership type to something that would break the donation sum requirement or maximum person requirement are blocked (Done)

### Affiliation Persons

* INSERT Triggers
    * Inserts that would result in an affiliation having different addresses are blocked. (Done)
    * Inserts that would result in an affiliation having too many people are blocked. (Done)
* UPDATE Triggers
    * All updates are blocked. (If needed, users can delete and create.) (Done)

### Physical and Mailing Address

* INSERT Triggers
    * Inserts for people that are in a current affiliation are blocked. (Users should use the affiliation address editor instead.) (Done)
* UPDATE Triggers
    * Updates for people that are in a current affiliation are blocked. (Users should use the affiliation address editor instead.) (Done)
    * Updates that move an address from one person to another are blocked. (Done)
    * Updates that change any part of the address will automatically reset the in_library_special_voting_district field, unless that field is included with the update. (Physical addresses only.) (Done)
* DELETE Triggers
    * Deletes for people that are in a current affiliation are blocked. (Users should use the affiliation address editor instead.) (Done)
