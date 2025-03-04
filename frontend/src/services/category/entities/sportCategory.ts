export interface SportCategory {
    id: number;
    name: string;
    description?: string;
    subcategories: SportCategory[] | [];
}