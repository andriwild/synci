
export type SyncConfigRequest = {
    id?: string
    name?: string
    events: EventDto[]
    teams: TeamDto[]
    sports: string[]
}
export type TeamDto = {
    id: string
    sourceId: number
}
export type EventDto = {
    id: string
    sourceId: number
}