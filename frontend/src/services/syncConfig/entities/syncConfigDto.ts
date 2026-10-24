export type SyncConfigRequest = {
    id?: string
    name?: string
    events: EventDto[]
    teams: TeamDto[]
    sports: string[]
    /** Top Events; leaving it out keeps the stored ones */
    matchups?: MatchupDto[]
}
export type TeamDto = {
    id: string
    sourceId: number
}
export type EventDto = {
    id: string
    sourceId: number
}
export type MatchupDto = {
    sourceId: number
    teamAId: string
    teamBId: string
}
