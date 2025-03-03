export interface SportCategory {
    id: number;
    name: string;
    subcategories: SportCategory[];
}