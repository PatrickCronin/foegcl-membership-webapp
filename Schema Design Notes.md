# Schema Design Notes

## Design Considerations

### Contributions

* Instead of the legacy term "donations", we now use "contribution" to allow   distinction between membership fees and donations, both of which are   "contributions."
* Contributions are only recorded against affililiations; not against people.

### Affiliations

* Affiliations may have a membership type assigned, making that particular affiliation also a membership. Memberships have a minimum donation sum requirement and a maximum person requirement, which is enforced by triggers.

### People

* All people sharing an affiliation of the current year should have the same physical and mailing addresses, both of which can be empty. This requirement cannot be enforced for historical years as we only store "current" addresses for people.

## Trigger Design

Triggers are used to support the following business rules that are not naturally supported by the schema design.

### Contributions

* UPDATE Triggers
    * Updates that move a contribution to another affiliation are blocked. (If needed, users can delete and create.) (Implemented + tested)
    * Updates that disqualify a membership's contribution sum requirement are blocked. (Implemented + tested)
* DELETE Triggers
    * Deletes that disqualify a membership's contribution sum requirement are blocked. (Implemented + tested)

### Affiliations

* INSERT Triggers
    * Inserts with a membership type without sufficient contributions or too many people are blocked. (Implemented + tested)
* UPDATE Triggers
    * Updates changing the affiliation's membership type to something that would break the contribution sum requirement or maximum person requirement are blocked. (Implemented + tested)

### Affiliation Persons

* INSERT Triggers
    * Inserts that would result in an affiliation having different addresses are blocked.
    * Inserts that would result in an affiliation having too many people are blocked.
* UPDATE Triggers
    * All updates are blocked. (If needed, users can delete and create.)

### Physical and Mailing Address

* INSERT Triggers
    * Inserts for people that are in a current affiliation are blocked. (Users should use the affiliation address editor instead.)
* UPDATE Triggers
    * Updates for people that are in a current affiliation are blocked. (Users should use the affiliation address editor instead.)
    * Updates that move an address from one person to another are blocked.
    * Updates that change any part of the address will automatically reset the in_library_special_voting_district field, unless that field is included with the update. (Physical addresses only.)
* DELETE Triggers
    * Deletes for people that are in a current affiliation are blocked. (Users should use the affiliation address editor instead.)
