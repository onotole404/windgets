windowsData = [
    {
        content: 'Sample content 1',
        title: 'Title 1'
    },
    {
        content: 'Sample content 2',
        title: 'Title 2'
    },
    {
        content: 'Sample content 3',
        title: 'Title 3'
    }
];

document.addEventListener('DOMContentLoaded', function(){
    window.windgets = new Windgets({
        container: document.getElementById('js-windgets-screen-container'),
        windowsData: windowsData
    });
});