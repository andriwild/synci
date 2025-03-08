import { SportCategory } from "./sport.ts";

export const sampleSportTree: SportCategory[] = [
    {
        "id": 1,
        "name": "Fussball",
        "description": "Fussball ist eine der beliebtesten Sportarten weltweit. Zwei Teams treten gegeneinander an, um den Ball ins gegnerische Tor zu schießen. Die Sportart erfordert Ausdauer, Technik und Teamgeist.",
        "subcategories": []
    },
    {
        "id": 2,
        "name": "Skifahren",
        "description": "Skifahren ist eine Wintersportart, bei der Athleten auf Skiern schneebedeckte Hänge hinabfahren. Es gibt verschiedene Disziplinen, darunter Slalom, Abfahrt und Riesenslalom.",
        "subcategories": [
            {
                "id": 3,
                "name": "Weltcup Damen",
                "description": "Der Weltcup Damen umfasst verschiedene Skirennen auf internationaler Ebene. Die besten Athletinnen der Welt messen sich in Disziplinen wie Slalom, Riesenslalom und Abfahrt.",
                "subcategories": [
                    {
                        "id": 4,
                        "name": "Slalom",
                        "description": "Slalom ist eine Disziplin des alpinen Skisports, bei der Athleten einen Kurs mit engen Toren durchfahren müssen. Es erfordert präzise Technik und schnelle Reaktionen.",
                        "subcategories": []
                    }
                ]
            },
            {
                "id": 5,
                "name": "Weltcup Herren",
                "description": "Der Weltcup Herren ist eine Serie internationaler Skirennen, bei denen die besten Skifahrer in verschiedenen Disziplinen antreten. Er gilt als einer der wichtigsten Wettkämpfe im Skisport.",
                "subcategories": [
                    {
                        "id": 6,
                        "name": "Riesenslalom",
                        "description": "Beim Riesenslalom müssen die Athleten einen Parcours mit weiter auseinanderliegenden Toren bewältigen. Die Disziplin erfordert eine Kombination aus Geschwindigkeit und Technik.",
                        "subcategories": []
                    },
                    {
                        "id": 7,
                        "name": "Super G",
                        "description": "Super G ist eine Kombination aus Abfahrt und Riesenslalom. Die Strecke ist schneller als beim Riesenslalom, erfordert aber dennoch präzise Kurvenfahrten.",
                        "subcategories": []
                    },
                    {
                        "id": 8,
                        "name": "Abfahrt",
                        "description": "Die Abfahrt ist die schnellste Disziplin im alpinen Skisport. Athleten erreichen hohe Geschwindigkeiten und müssen lange, fließende Kurven meistern.",
                        "subcategories": []
                    }
                ]
            }
        ]
    },
    {
        "id": 9,
        "name": "Unihockey",
        "description": "Unihockey ist eine schnelle Hallensportart, die dem Eishockey ähnelt, aber ohne Schlittschuhe gespielt wird. Zwei Teams versuchen, mit einem leichten Plastikball Tore zu erzielen.",
        "subcategories": []
    },
    {
        "id": 10,
        "name": "Basketball",
        "description": "Basketball ist ein temporeiches Mannschaftsspiel, bei dem der Ball in den Korb des Gegners geworfen wird. Es erfordert Geschick, Teamarbeit und präzises Werfen.",
        "subcategories": []
    },
    {
        "id": 11,
        "name": "Eishockey",
        "description": "Eishockey ist ein rasanter Mannschaftssport auf dem Eis. Spieler bewegen sich mit Schlittschuhen fort und nutzen einen Schläger, um den Puck ins gegnerische Tor zu befördern.",
        "subcategories": []
    },
    {
        "id": 12,
        "name": "Handball",
        "description": "Handball ist ein körperbetontes Mannschaftsspiel, bei dem zwei Teams versuchen, mit Würfen den Ball ins gegnerische Tor zu befördern. Es erfordert Schnelligkeit, Taktik und Wurfkraft.",
        "subcategories": []
    }
];
