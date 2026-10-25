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

export type EventAnswer = "YES" | "NO";

/** Answers of the active members to an event that asks for them. */
export interface EventResponseSummary {
    eventId: string;
    yes: number;
    no: number;
    /** active members without an answer */
    open: number;
    myAnswer: EventAnswer | null;
    /** every active member with their answer; only for admins */
    members: { name: string | null; answer: EventAnswer | null }[] | null;
}

/** What the answer link in the calendar shows: the event and the answer of the calendar's owner. */
export interface EventInvitation {
    eventId: string;
    name: string;
    startsOn: string;
    /** missing for all-day events */
    endsOn?: string;
    location?: string;
    organisation: string;
    answer: EventAnswer | null;
}
