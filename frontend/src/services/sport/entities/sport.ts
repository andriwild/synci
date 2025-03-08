export interface Sport {
    id: string;
    name: string;
    subSports: Sport[] | [];
}