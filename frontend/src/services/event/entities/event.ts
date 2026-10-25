import {Team} from "../../team/entities/team.ts";

export interface SportEvent {
    id: string;
    sourceId: number;
    name: string;
    startsOn: string;
    endsOn?: string;
    sportId: string;
    locationId?: string;
    location?: string;
    description?: string;
    rootSport?: string;
    /** organisation events can ask their members to answer yes or no */
    responseRequested?: boolean;
    /** both teams of a game in the order of its name; empty for events without teams */
    teams?: Team[];
}
