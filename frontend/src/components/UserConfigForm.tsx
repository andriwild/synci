import {Button, Card, Flex, Form, List, Select, Typography} from "antd";
import {useNavigate, useParams} from "react-router-dom";
import {Copy, Plus} from "@phosphor-icons/react";

interface Team {
    id: string;
    name: string;
}
export type UserConfigValues = Team;

export const UserConfigForm = () => {
    const [form] = Form.useForm<UserConfigValues>();
    const navigate = useNavigate();
    const {id} = useParams();

    const dataSource = [
        {
            id: '1',
            label: 'SuperLeague Spiele',
            teams: ['YoungBoys, Basel, Zürich, Lausanne'],
            url: 'https://google.ch',
        },
        {
            id: '2',
            label: 'Manchester Konfig',
            teams: ['Manchester United'],
            url: 'https://google.ch',
        },
        {
            id: '3',
            label: 'Manchester Konfig',
            teams: ['Manchester United'],
            url: 'https://google.ch',
        },
        {
            id: '4',
            label: 'Manchester Konfig',
            teams: ['Manchester United'],
            url: 'https://google.ch',
        },
        {
            id: '5',
            label: 'Manchester Konfig',
            teams: ['Manchester United'],
            url: 'https://google.ch',
        },
        {
            id: '6',
            label: 'Manchester Konfig',
            teams: ['Manchester United'],
            url: 'https://google.ch',
        },
    ];

    const teams: Team[] = [
        { id: 'teamA', name: 'Team A' },
        { id: 'teamB', name: 'Team B' },
        { id: 'teamC', name: 'Team C' },
    ];

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
                    <Select
                        options={teams.map((team) => ({
                            label: team.name,
                            value: team.id,
                        }))}
                        style={{ width: 300 }}
                        mode="multiple"
                        showSearch
                        allowClear
                        filterOption={(input, option) =>
                            (option?.label ?? '').toLowerCase().includes(input.toLowerCase())
                        }
                        placeholder="Wähle ein Team aus"
                    />
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
