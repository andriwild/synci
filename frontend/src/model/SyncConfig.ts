import { Team } from "./Team.ts";

export interface SyncConfig {
    id: string | null;
    name: string;
    teams: Team[];
}
