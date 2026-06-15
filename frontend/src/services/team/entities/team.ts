export const displayGender = (gender: Team["gender"]) => {
    switch (gender) {
        case "WOMAN": return "(W)";
        case "BOTH": return "(W/M)";
        default: return "";
    }
};

export interface Team {
    id: string;
    name: string;
    sourceId: number;
    gender: "WOMAN" | "MAN"| "BOTH" | "UNKNOWN";
    rootSport?: string;
}
