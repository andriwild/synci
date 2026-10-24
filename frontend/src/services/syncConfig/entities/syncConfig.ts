import { Team } from "../../team/entities/team.ts";
import {Sport} from "../../sport/entities/sport.ts";
import {SportEvent} from "../../event/entities/event.ts";

/** A Top Event: every game between the two teams. */
export interface Matchup {
    sourceId: number;
    teamA: Team;
    teamB: Team;
    rootSport?: string;
}

export interface SyncConfig {
    id: string;
    name: string;
    sports: Sport[];
    teams: Team[];
    events: SportEvent[];
    matchups?: Matchup[];
    /** how many Top Events the Abo may hold */
    matchupLimit?: number;
}
