export interface User {
    email: string;
    /** display name from the Auth0 profile */
    name?: string;
    firstName: string;
    lastName: string;
    picture?: string;
}
