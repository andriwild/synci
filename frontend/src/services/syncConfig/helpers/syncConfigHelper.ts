import {SyncConfigRequest} from "../entities/syncConfigDto.ts";
import {SyncConfig} from "../entities/syncConfig.ts";

export const syncConfigDtoMapper = (syncConfig: SyncConfig): SyncConfigRequest => {
    return {
        id: syncConfig.id,
        name: syncConfig.name,
        events: syncConfig.events.map(event => ({
            id: event.id,
            sourceId: event.sourceId
        })),
        teams: syncConfig.teams.map(team => ({
            id: team.id,
            sourceId: team.sourceId
        })),
        sports: syncConfig.sports.map(sport => sport.name)
    }

}