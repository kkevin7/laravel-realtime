@extends('layouts.app')

@push('styles')
<style type="text/css">
    @keyframes rotate {
        from {
            transform: rotate(0deg);
        }

        to {
            transform: rotate(360deg);
        }
    }

    .refresh {
        animation: rotate 1.5s linear infinite;
    }
</style>
@endpush

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">{{ __('Game') }}</div>

                <div class="card-body">
                    <div class="text-center">
                        <img id="circle" src="{{ asset('img/circle.png') }}" class="refresh" alt="circle" width="250"
                            height="250">
                        <p id="winner" class="display-1 d-none text-primary">10</p>
                    </div>
                </div>

                <hr>

                <div class="text-center">
                    <label for="font-weight-bold h5">Your bet</label>
                    <select name="bet" id="bet" class="custom-select col-auto">
                        <option value="" selected>Not in</option>
                        @foreach (range(1, 12) as $number)
                        <option value="{{ $number }}">{{ $number }}</option>
                        @endforeach
                    </select>
                    <hr>
                    <p class="font-weight-bold h5">Remaning Time</p>
                    <p id="timer" class="h5 text-danger">Waiting to start</p>
                    <hr>
                    <p id="result" class="h1"></p>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script type="module">
    const circleElement = document.getElementById('circle');
    const timerElement = document.getElementById('timer');
    const winnerElement = document.getElementById('winner');
    const betElement = document.getElementById('bet');
    const resultElement = document.getElementById('result');

    Echo.channel('game')
    .listen('RemaningTimeChanged', (e) => {
        timerElement.innerText = e.time;
        circleElement.classList.add('refresh');
        resultElement.innerText = '';
        winnerElement.classList.add('d-none');
        winnerElement.classList.remove('text-success');
        winnerElement.classList.remove('text-danger');
    })
    .listen('WinnerNumberGenerated', (e) => {
        circleElement.classList.remove('refresh');

        let winner = e.number;
        winnerElement.innerText = winner;
        winnerElement.classList.remove('d-none');

        let bet = betElement[betElement.selectedIndex].innerText;
        if(bet == winner) {
            resultElement.innerText = 'You WIN';
            resultElement.classList.add('text-success');
        }else{
            resultElement.innerText = 'You LOST';
            resultElement.classList.add('text-danger');
        }
    })
</script>
@endpush
