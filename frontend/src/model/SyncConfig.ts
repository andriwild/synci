import { Team } from "./Team.ts";
import {Sport} from "../services/sport/entities/sport.ts";

export interface SyncConfig {
    id: string;
    name: string;
    teams: Map<Team, Sport[]>;
    sports: Sport[];
    events: Event[];
}
