<?php

namespace App\Console\Commands;

use App\Events\RemaningTimeChanged;
use App\Events\WinnerNumberGenerated;
use Illuminate\Console\Command;

class GameExecutor extends Command
{

    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'game:excute';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Start executing the game.';

    private $time = 15;


    /**
     * Execute the console command.
     *
     * @return int
     */
    public function handle()
    {
        while (true) {
            broadcast(new RemaningTimeChanged($this->time . 's'));

            $this->time--;
            sleep(1);

            if ($this->time === 0) {
                $this->time = 'Waiting to start';

                broadcast(new RemaningTimeChanged($this->time));
                broadcast(new WinnerNumberGenerated(mt_rand(1, 12)));

                sleep(5);
                $this->time = 15;
            }
        }
    }
}
