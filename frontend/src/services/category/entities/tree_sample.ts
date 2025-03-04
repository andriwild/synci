import {SportCategory} from "./sportCategory.ts";

export const sampleSportTree : SportCategory[] = [
    {
        "id": 1,
        "name": "Fussball",
        "subcategories": []
    },
    {
        "id": 2,
        "name": "Skifahren",
        "subcategories": [
            {
                "id": 3,
                "name": "Weltcup Damen",
                "subcategories": [
                    { "id": 4, "name": "Slalom", "subcategories": [] }
                ]
            },
            {
                "id": 5,
                "name": "Weltcup Herren",
                "subcategories": [
                    { "id": 6, "name": "Riesenslalom", "subcategories": [] },
                    { "id": 7, "name": "Super G", "subcategories": [] },
                    { "id": 8, "name": "Abfahrt", "subcategories": [] }
                ]
            }
        ]
    },
    {
        "id": 9,
        "name": "Unihockey",
        "subcategories": []
    },
    {
        "id": 10,
        "name": "Basketball",
        "subcategories": []
    },
    {
        "id": 11,
        "name": "Eishockey",
        "subcategories": []
    },
    {
        "id": 12,
        "name": "Handball",
        "subcategories": []
    }
];
