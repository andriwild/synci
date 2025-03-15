export interface Sport {
    id: string;
    name: string;
    label: string;
    subSports: Sport[] | [];
}