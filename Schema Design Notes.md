# Schema Design Notes

## Notes

* Instead of the legacy term "donations", we now use "contribution" to allow distinction between membership fees and donations, both of which are "contributions."
* Contributions are recorded against affililiations, not people.
* The Contributions received date must have the same year as the contribution's affiliation.

## Data Integrity Rules

### Definitions

* **Affiliation Person Integrity:** An affiliation cannot exist without at least one person.
* **Affiliation Contribution Integrity:** An affiliation cannot exist without at least one contribution.
* **Current Year Affiliation Person Address Integrity:** An affiliation cannot exist for the current year if it's people have different physical or mailing addresses.
* **Membership Maximum Person Integrity:** A membership cannot have more than the maximum number of associated people.
* **Membership Minimum Contribution Integrity:** A membership cannot have less than the minimum sum of contributions.

### Triggers

#### Contribution Triggers

* When a contribution is created, updated or delete, ensure the following is maintained for both the old/new affiliations:

    * Membership Minimum Contribution Integrity

* When a contribution is created or updated, its received date must be in the same year as the affiliation it's associated with.

#### Affiliation Triggers

* When an affiliation is created or updated, ensure the following are maintained for both old and new affiliations:

    * Affiliation Person Integrity
    * Affiliation Contribution Integrity
    * Current Year Affiliation Person Address Integrity
    * Membership Maximum Person Integrity
    * Membership Minimum Contribution Integrity

#### Affiliation People Triggers

* When an association between a person and an affiliation is created, updated or deleted, ensure the following are maintained for both old and new affiliations:

    * Affiliation Person Integrity
    * Current Year Affiliation Person Address Integrity
    * Membership Maximum Person Integrity

### People Triggers

* When a person is created, updated, or deleted, ensure the following are maintained for both old and new affiliations:

    * Nothing!

### Physical and Mailing Addresses

* When a physical or mailing address is created, updated or deleted, ensure the following are maintained for both old and new affiliations:

    * Current Year Affiliation Person Address Integrity

* When a physical address is updated, its In Library Special Voting District field will be cleared.
