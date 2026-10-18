export interface SportEvent {
    id: string;
    sourceId: number;
    name: string;
    startsOn: string;
    endsOn?: string;
    sportId: string;
    locationId?: string;
    location?: string;
    description?: string;
    rootSport?: string;
}
