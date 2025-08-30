const app = Vue.createApp({
    data() {
        return {
            blips: [],
            jobicons: [],
            opened: false,
            editor: false,
            search: "",
            newblip: {
                name: "",
                sprite: 0,
                colour: 0,
                scale: 1,
                job: "",
                radius: false,
                spirename: "",
                colorhax: "",
                radiusShow: false,
            },
            editblip: {
                name: "",
                sprite: 0,
                colour: 0,
                scale: 1,
                job: "",
                radius: false,
                spirename: "",
                colorhax: "",
                radiusShow: false,
            },
            editortype: "",
        }
    },
    computed: {
        Blipselection(){
            if (this.search === ""){return this.blips}

            const lowsearch = this.search.toLowerCase();

            return this.blips.filter((blip) => {
                return blip.name.toLowerCase().includes(lowsearch)
            });
        }
    },
    methods: {
        Key(e){if(e.key === 'Escape'){this.ClosePanel()}},
        ClosePanel(){
            if (this.editor){
                this.SetEditorState(false)
                setTimeout(() => {this.opened = false},500)
                fetch(`https://${GetParentResourceName()}/close`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({})
                })
                .then(r => {
                    if (r.ok){
                        this.blips = []
                        this.newblip = {
                            name: "",
                            sprite: 0,
                            colour: 0,
                            scale: 1,
                            radius: false
                        }
                    }
                })
            } else {
                fetch(`https://${GetParentResourceName()}/close`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({})
                })
                .then(r => {
                    if (r.ok){
                        this.opened = false
                        this.blips = []
                        this.newblip = {
                            name: "",
                            sprite: 0,
                            colour: 0,
                            scale: 1,
                            radius: false
                        }
                    }
                })
            }
        },
        GetBlips(){
            fetch(`https://${GetParentResourceName()}/getJSON`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({})
            })
            .then(r => r.json())
            .then(d => {
                this.blips = JSON.parse(d)
            })
        },
        SetEditorState(state){
            const editor = document.querySelector('.newblip')
            const main = document.querySelector('.panel')
            if (state){
                this.editor = true
                this.GetSpriteImg(this.editortype == 'edit'? 'editblip':'newblip')
                this.GetBlipColor(this.editortype == 'edit'? 'editblip':'newblip')
                editor.style = 'animation: becsuszik 0.5s ease-in-out;'
                setTimeout(() => {
                    main.style = 'left: 50%;'
                    editor.style = 'left: 64%;'
                }, 490)
            } else {
                editor.style = 'animation: kicsuszik 0.5s ease-in-out;'
                main.style = 'left: 50%;'
                setTimeout(() => {
                    this.editor = false
                    editor.style = 'left: 100%;'
                }, 490)
            }
        },
        TPBlip(c){
            fetch(`https://${GetParentResourceName()}/tpcoord`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(c)
            })
            .then(r => {
                if (r.ok){
                    this.ClosePanel()
                }
            })
        },
        CreateBlip(){
            fetch(`https://${GetParentResourceName()}/createblip`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(this.newblip)
            })
            .then(r => {
                if (r.ok){
                    this.GetBlips()
                }
            })
        },
        GetSpriteImg(type){
            fetch(`https://${GetParentResourceName()}/getspritename`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(this[type].sprite)
            })
            .then(r => r.json())
            .then(d => {
                this[type].spirename = d
            })
        },
        GetSprite(type){
            return `https://docs.fivem.net/blips/${this[type].spirename}.png`
        },
        GifCsere(e){
            if (e.target.src.endsWith(".png")) {
                e.target.src = e.target.src.replace(".png", ".gif")
            }
        },
        GetBlipColor(type){
            fetch(`https://${GetParentResourceName()}/GetBlipColor`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(this[type].colour)
            })
            .then(r => r.json())
            .then(d => {
                this[type].colorhax = d
            })
        },
        DeleteBlip(id){
            fetch(`https://${GetParentResourceName()}/deleteblip`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(id)
            })
            .then(r => {
                if (r.ok){
                    this.GetBlips()
                }
            })
        },
        Edit(i){
            this.editblip = i
            this.editortype = 'edit'
            this.SetEditorState(!this.editor)
        },
        SaveEdit(){
            fetch(`https://${GetParentResourceName()}/save`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(this.editblip)
            })
            .then(r => {
                if (r.ok){
                    this.GetBlips()
                }
            })
        },
    },
    mounted() {
        window.addEventListener('keydown', this.Key)
        window.addEventListener('message', (e) => {
            const a = e.data
            if (a.type === 'open'){
                this.GetBlips()
                this.opened = true
                this.jobicons = a.jobs
            }
        })
    },
})
app.mount('#app');