import { Team } from "../../team/entities/team.ts";
import {Sport} from "../../sport/entities/sport.ts";
import {SportEvent} from "../../event/entities/event.ts";

export interface SyncConfig {
    id: string;
    name: string;
    sports: Sport[];
    teams: Team[];
    events: SportEvent[];
}
