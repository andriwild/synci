import {Sport} from "../../sport/entities/sport.ts";

export type OrgRole = "ADMIN" | "MEMBER";
export type OrgMemberStatus = "PENDING" | "ACTIVE";

/** An organisation the current user belongs to (active or pending) with its subtree in the sport tree. */
export interface MyOrganisation {
    id: string;
    name: string;
    description?: string;
    role: OrgRole;
    status: OrgMemberStatus;
    /** root node; its subSports are the groups */
    sport: Sport;
}

/** Listing entry for "Organisationen entdecken". */
export interface OrganisationSummary {
    id: string;
    name: string;
    description?: string;
    memberCount: number;
    membershipStatus?: OrgMemberStatus;
    role?: OrgRole;
}

/** Detail view for active members. */
export interface Organisation {
    id: string;
    name: string;
    description?: string;
    role: OrgRole;
    sport: Sport;
}

export interface OrganisationMember {
    id: string;
    userId: string;
    name?: string;
    email?: string;
    role: OrgRole;
    status: OrgMemberStatus;
    createdAt?: string;
    isMe: boolean;
}

export const roleLabel = (role: OrgRole) => role === "ADMIN" ? "Admin" : "Mitglied";
