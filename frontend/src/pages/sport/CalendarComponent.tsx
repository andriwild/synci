import {Alert, Button, Flex, Typography} from "antd";
import {CalendarSelectionModal} from "../../components/calenderSelectionModal/CalenderSelectionModal.tsx";
import {IconReplace, IconSwitch, IconSwitch2} from "@tabler/icons-react";
import {syncConfigApi} from "../../services/config/syncConfigApi.ts";
import {SyncConfig} from "../../services/config/entities/syncConfig.ts";
import {useState} from "react";
import {Team} from "../../model/Team.ts";
import {Sport} from "../../services/sport/entities/sport.ts";

export const CalendarComponent = () => {

    //const syncConfigList = syncConfigApi.useGetAllQuery();

    const [currentSyncConfig, setCurrentSyncConfig] = useState<SyncConfig | null>(null);

    setCurrentSyncConfig(
        {
            id: "55e8b617-be90-42ed-a75f-89f374ca303c",
            name: "Kalender Elias",
            teams: new Map<Team, Sport[]>(),
            sports: [
                {
                    id: "1",
                    name: "Fussball",
                    subSports: [],
                },
                {
                    id: "2",
                    name: "Handball",
                    subSports: [],
                },
                {
                    id: "3",
                    name: "Volleyball",
                    subSports: [],
                },
            ],
            events: [
                {
                    id: "1",
                    name: "Fussball Match",
                    startsOn: "heute",
                    endsOn: "morgen",
                    sportId: "1",
                    locationId: "1",
                },
                {
                    id: "2",
                    name: "Handball Match",
                    startsOn: "heute",
                    endsOn: "morgen",
                    sportId: "2",
                    locationId: "2",
                },
                {
                    id: "3",
                    name: "Volleyball Match",
                    startsOn: "heute",
                    endsOn: "morgen",
                    sportId: "3",
                    locationId: "3",
                },

            ],
        }
    );



            return (
        <Flex vertical style={{gap: 20, padding: "20px 20px"}}>
            <Flex justify={"space-between"}>
            {/*TODO Edit field*/}
            <Typography.Title level={2} style={{margin: 0}}>currentSyncConfig.name</Typography.Title>
            <Button icon={<IconReplace size={20}/>} type={"default"}></Button>
            </Flex>
                <Alert
                    message="Du bis noch nicht angemeldet"
                    description="Melde dich an, um deine Abos zu sehen"
                    type="warning"
                    showIcon
                    action={
                        <Button>Anmelden</Button>
                    }
                />
            <CalendarSelectionModal
                url="localhost:8080/api/calendar/subscribe/55e8b617-be90-42ed-a75f-89f374ca303c"
                buttonText="Zu Kalender hinzufügen"
                buttonIcon={<i className="fas fa-calendar-plus"></i>}
                buttonType="primary"

            />

        </Flex>
    );
}