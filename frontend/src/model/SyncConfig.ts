import {Team} from "./Team.ts";

export interface SyncConfig {
    id: string;
    url: string;
    teams: Team[];
}