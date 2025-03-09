import {Alert, Button, Flex} from "antd";
import {CalendarSelectionModal} from "../../components/calenderSelectionModal/CalenderSelectionModal.tsx";
import {Login} from "../login/Login.tsx";
import {useState} from "react";

export const CalendarComponent = () => {
    const [isLoginModalOpen, setIsLoginModalOpen] = useState(false);

    return (
        <Flex vertical style={{gap: 20, padding: "0 20px"}}>

            <h1>Meine Abos</h1>
                <Alert
                    message="Du bis noch nicht angemeldet"
                    description="Melde dich an, um deine Abos zu sehen"
                    type="warning"
                    showIcon
                    action={
                        <Button onClick={() => setIsLoginModalOpen(true)}>Anmelden</Button>
                    }
                />
            <Login isOpen={isLoginModalOpen} onClose={() => setIsLoginModalOpen(false)} />

            <CalendarSelectionModal
                url="localhost:8080/api/calendar/subscribe/55e8b617-be90-42ed-a75f-89f374ca303c"
                buttonText="Zu Kalender hinzufügen"
                buttonIcon={<i className="fas fa-calendar-plus"></i>}
                buttonType="primary"
            />

        </Flex>
    );
}