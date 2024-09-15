import {Button, Card, Flex, Form, List, Select, Typography} from "antd";
import {useNavigate, useParams} from "react-router-dom";
import {Copy, Plus} from "@phosphor-icons/react";
import {useEffect, useState} from "react";
import {TeamSelect} from "../components/TeamSelect.tsx";

interface Team {
    id: string;
    name: string;
}
export type UserConfigValues = Team;

export const UserConfigForm = () => {
    const [form] = Form.useForm<UserConfigValues>();
    const navigate = useNavigate();
    const {id} = useParams();
    const createmode = id === 'create';

    const [teams, setTeams] = useState<Team[]>([]);

    const [syncConfig, setSyncConfig] = useState(false);

    useEffect(() => {
        fetch('https://localhost:8080/api/syncconfig/' + id, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(teams),
        })
            .then(response => response.json())
            .then(data => {
                    console.log(data);
                    setSyncConfig(data);
                }
            )
            .catch(error => console.error('Error:', error));
    }, []);

    const handleSubmit = (values: UserConfigValues) => {
        console.log('Form submitted:', values);
    };

    const handleBack = () => {
        console.log('Zurück-Button geklickt');
        navigate('/');
    };

    return (
        <Flex vertical style={{height: '100%', width: '100%', padding: 24}}>
        <Card style={{ width: 600, textAlign: 'left' }}>
            <h2 style={{ marginBottom: '20px' }}>Abonement {id}</h2>
            <p>Füge eine Konfiguration hinzu. Wähle dabei aus, für welches Team, welchen Sportler, welchen Ort oder
                welche Sportart du dich interessierst</p>
            <Form<UserConfigValues> form={form} onFinish={handleSubmit} layout={'vertical'} style={{marginTop: 36}}>
                <Form.Item name={'teams'} label={'Teams'}>
                    <TeamSelect/>
                </Form.Item>
                <Flex gap={'middle'} justify={'end'} style={{marginTop: 48, marginBottom: 12 }}>
                    <Button onClick={handleBack}>
                        Zurück
                    </Button>
                    <Button htmlType={'submit'} type={'primary'}>
                        Submit
                    </Button>
                </Flex>
            </Form>
             </Card>
        </Flex>
    );
};
