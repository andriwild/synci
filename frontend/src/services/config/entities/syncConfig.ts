import { Team } from "../../../model/Team.ts";
import {Sport} from "../../sport/entities/sport.ts";
import {SportEvent} from "../../event/entities/event.ts";

export interface SyncConfig {
    id: string;
    name: string;
    teams: Map<Team, Sport[]>;
    sports: Sport[];
    events: SportEvent[];
}
