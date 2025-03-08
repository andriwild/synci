import {Alert, Button, Flex} from "antd";
import {CalendarSelectionModal} from "../../components/calenderSelectionModal/CalenderSelectionModal.tsx";

export const CalendarComponent = () => {
    return (
        <Flex vertical style={{gap: 20, padding: "0 20px"}}>

            <h1>Meine Abos</h1>
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
                url="http://localhost:8080/api/calendar/subscribe/55e8b617-be90-42ed-a75f-89f374ca303c"
                buttonText="Zu Kalender hinzufügen"
                buttonIcon={<i className="fas fa-calendar-plus"></i>}
                buttonType="primary"
            />

        </Flex>
    );
}