export interface Sport {
    id: string;
    name: string;
    label: string;
    subSports: Sport[] | [];
    /** set when the node is an organisation or one of its groups */
    organisationId?: string;
    rootSport?: string;
}
