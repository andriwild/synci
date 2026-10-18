export type OrganisationRequest = {
    name: string;
    description?: string;
};

export type GroupRequest = {
    name: string;
};

export type OrganisationEventRequest = {
    name: string;
    description?: string;
    location?: string;
    /** ISO local date-time without zone, e.g. 2026-10-13T19:00:00 */
    startsOn: string;
    /** omitted = all-day event */
    endsOn?: string;
    /** the organisation's root sport or one of its groups */
    sportId: string;
};
