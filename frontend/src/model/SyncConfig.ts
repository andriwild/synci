import { Team } from "./Team.ts";
import { Sport } from "./Sport.ts";

export interface SyncConfig {
    id: string | null;
    name: string;
    teams: Team[];
    sports: Sport[];
}
